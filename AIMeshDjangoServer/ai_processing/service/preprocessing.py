import os
import json
import tensorflow as tf
from transformers import BertTokenizer
from sklearn.preprocessing import MultiLabelBinarizer
from django.conf import settings
import spacy
import sparknlp
from sparknlp.annotator import DocumentAssembler, DateMatcher, MultiDateMatcher
from pyspark.sql.types import StringType
from pyspark.ml import Pipeline
from datetime import datetime


class Preprocessor:
    def __init__(self):
        """
        Initialize the Preprocessor class.

        This method initializes various components required for preprocessing tasks, including a BERT tokenizer,
        Spark NLP components, a multi-label binarizer, and other necessary variables.
        """
        self.tokenizer = BertTokenizer.from_pretrained('bert-base-uncased')

        self.spark = sparknlp.start()
        self.documentAssembler = DocumentAssembler().setInputCol("text").setOutputCol("document")
        self.multiDateMatcher = MultiDateMatcher().setInputCols("document").setOutputCol("multi_date").setOutputFormat(
            "MM/dd/yy")

        # Inițializare spaCy
        # spacy.cli.download("en_core_web_sm")
        # run this command in cmd "python -m spacy download en_core_web_sm"
        self.sp_sm = spacy.load('en_core_web_sm')

        self.mlb = None
        self.classes = None
        self.initialize()

    def initialize(self):
        """
        Initialize the preprocessor.

        This method initializes the preprocessor by preparing the data from a JSON file and extracting titles and
        MeSH labels from the data.
        """
        file_path = os.path.join(settings.BASE_DIR, 'ai_processing', 'service', 'resources', 'dataset',
                                 'data_100_700_with_abstract.json')
        titles, labels, classes = self.prepare_data(file_path)
        self.classes = classes
        print(self.classes)

    def predict_mesh_labels(self, sentence, model):
        """
        Predict MeSH labels for a given sentence.

        Args:
        sentence (str): The input sentence.
        model: The TensorFlow model used for prediction.

        Returns:
        list: A list of predicted MeSH labels.

        This method predicts MeSH labels for a given sentence using the provided TensorFlow model and returns the
        predicted labels.
        """
        inputs = self.tokenizer.encode_plus(sentence, return_tensors='tf', max_length=512, truncation=True,
                                            padding='max_length')
        outputs = model(inputs)

        predictions = tf.nn.sigmoid(outputs.logits)
        predicted_labels = [self.classes[i] for i, value in enumerate(predictions[0]) if value > 0.4]

        return predicted_labels

    def prepare_data(self, file_path):
        """
          Loads data from a JSON file, extracts titles and MeSH labels, and converts the labels into binary format.

          Args:
              file_path (str): Path to the JSON file containing the data.

          Returns:
              tuple: A tuple containing three elements:
                     - List of titles (list of str)
                     - Binary labels (2D numpy array)
                     - Classes (array): Array of class labels used in the binarizer.

          The function first loads the data from the specified JSON file. It then extracts the titles and MeSH labels from
          the data. These MeSH labels are converted into a binary format using MultiLabelBinarizer from scikit-learn, which
          is suitable for multi-label classification tasks. The function returns the titles, the binary labels, and the
          classes (labels) used in the binarizer.
          """
        with open(file_path, 'r') as file:
            data = json.load(file)

        titles = [item['title'] for item in data]
        mesh_labels = [list(item['mesh'].values()) for item in data]

        self.mlb = MultiLabelBinarizer()
        binary_labels = self.mlb.fit_transform(mesh_labels)

        return titles, binary_labels, self.mlb.classes_

    def extract_dates_and_people(self, text):
        """
        Extract dates and people from text.

        Args:
        text (str): The input text.

        Returns:
        tuple: A tuple containing date range and extracted people.

        This method extracts dates and people from the input text using Spark NLP and spaCy, and returns the extracted
        information.
        """
        spark_df = self.spark.createDataFrame([text], StringType()).toDF("text")

        pipeline = Pipeline().setStages([self.documentAssembler, self.multiDateMatcher])
        result = pipeline.fit(spark_df).transform(spark_df)
        dates_result = result.selectExpr("text", "multi_date.result as multi_date")

        dates = dates_result.collect()[0]
        extracted_dates = dates["multi_date"]

        if extracted_dates:
            extracted_dates = [datetime.strptime(date, "%m/%d/%y") for date in extracted_dates]
            date_range = (min(extracted_dates), max(extracted_dates))
        else:
            date_range = None
        spacy_doc = self.sp_sm(text)
        extracted_people = [ent.text for ent in spacy_doc.ents if ent.label_ == "PERSON"]

        return date_range, extracted_people
