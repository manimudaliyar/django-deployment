from django.http import JsonResponse


def home(_request):
    return JsonResponse({"message": "Simple Django deployment demo"})


def health(_request):
    return JsonResponse({"status": "ok"})
