import os

from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from django.conf import settings
from django.apps import apps
from .service.postprocessing import get_articles_list
from .service.auth import check_firebase_token
import json
from django.http import JsonResponse
from django.apps import apps
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def predict_mesh_labels_view(request):
    if request.method == 'POST':
        try:
            ai_processing_config = apps.get_app_config('ai_processing')
            preprocessor = ai_processing_config.preprocessor
            model_loader = ai_processing_config.modelLoader

            data = json.loads(request.body.decode('utf-8'))
            text = data.get('text')

            auth_header = request.headers.get('Authorization')
            if auth_header and auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]

                if check_firebase_token(token):
                    print('Token valid')
                else:
                    print('Token invalid')
                    return JsonResponse({'error': 'Invalid token'}, status=401)
            else:
                return JsonResponse({'error': 'Authorization token not provided'}, status=401)

            model = model_loader.getModel()
            predicted_labels = preprocessor.predict_mesh_labels(sentence=text, model=model)
            extracted_dates, extracted_people = preprocessor.extract_dates_and_people(text)

            print(extracted_dates, extracted_people)
            print(predicted_labels)

            articles_info = get_articles_list(predicted_labels, extracted_dates, extracted_people)

            return JsonResponse({'articles': articles_info})

        except json.JSONDecodeError:
            return JsonResponse({'error': 'Format invalid al datelor JSON'}, status=400)
    else:
        return JsonResponse({'error': 'Metoda HTTP nu este acceptată'}, status=405)
