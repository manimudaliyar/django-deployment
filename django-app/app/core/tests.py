from django.test import SimpleTestCase
from django.urls import reverse


class CoreViewTests(SimpleTestCase):
    def test_home_returns_demo_message(self):
        response = self.client.get(reverse("home"))

        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(
            response.content,
            {"message": "Simple Django deployment demo"},
        )

    def test_health_returns_ok_status(self):
        response = self.client.get(reverse("health"))

        self.assertEqual(response.status_code, 200)
        self.assertJSONEqual(response.content, {"status": "ok"})
