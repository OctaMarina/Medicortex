import os

from django.apps import AppConfig
from django.conf import settings


class AiProcessingConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'ai_processing'

    def ready(self):
        from .service.preprocessing import Preprocessor
        from .service.model_loading import ModelLoader
        # Atașează preprocessor și modelLoader la instanța AiProcessingConfig ca atribute
        self.preprocessor = Preprocessor()

        model_dir = os.path.join(settings.BASE_DIR, "ai_processing", "service", "resources", "model", "bert_1_700",
                                 "700_labels_model", "700_labels_model")
        self.modelLoader = ModelLoader(model_dir)
