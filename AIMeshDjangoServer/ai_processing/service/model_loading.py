import tensorflow as tf
from transformers import TFBertForSequenceClassification


class ModelLoader:
    def __init__(self, load_path, learning_rate=3e-5):
        """
        Constructorul clasei.

        Args:
            load_path (str): Calea către directorul în care este salvat modelul pre-antrenat.
            learning_rate (float, optional): Rata de învățare pentru optimizatorul Adam. Implicit este 3e-5.
        """
        self.load_path = load_path
        self.learning_rate = learning_rate
        self.model = self.load_and_compile_model()

    def load_and_compile_model(self):
        """
        Încarcă un model BERT pre-antrenat pentru clasificare secvențială dintr-o cale specificată și îl compilează.

        Returns:
            TFBertForSequenceClassification: Un model BERT compilat gata pentru antrenare, evaluare sau predicție.
        """
        # Încarcă modelul BERT pre-antrenat
        model = TFBertForSequenceClassification.from_pretrained(self.load_path)

        # Compilează modelul cu optimizatorul Adam și funcția de pierdere Sparse Categorical Crossentropy
        optimizer = tf.keras.optimizers.Adam(learning_rate=self.learning_rate)
        loss = tf.keras.losses.SparseCategoricalCrossentropy(from_logits=True)
        model.compile(optimizer=optimizer, loss=loss, metrics=['accuracy'])

        return model

    def getModel(self):
        return self.model
