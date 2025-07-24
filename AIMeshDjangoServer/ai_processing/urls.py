from django.urls import path
from . import views

urlpatterns = [
    path('predict/', views.predict_mesh_labels_view, name='predict_mesh_labels'),
]