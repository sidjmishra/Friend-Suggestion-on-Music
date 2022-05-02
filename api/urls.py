from django.urls import path
from .views import SuggestUsers

urlpatterns = [
    path("getMatches", SuggestUsers.as_view()),
]
