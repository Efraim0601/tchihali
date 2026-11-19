"""Envoi des codes SMS.

Le fournisseur réel (opérateur, agrégateur SMS camerounais, etc.) n'est pas encore choisi :
il suffit d'écrire une classe avec une méthode `send(phone, text)` et de l'ajouter à `get_sms`.
"""

import logging
from typing import Protocol

from .config import settings

log = logging.getLogger("tchihali.sms")


class SmsProvider(Protocol):
    def send(self, phone: str, text: str) -> None: ...


class ConsoleSms:
    """Développement seulement : écrit le message dans les journaux au lieu de l'envoyer."""

    def send(self, phone: str, text: str) -> None:
        log.warning("SMS (console, non envoyé) à %s : %s", phone, text)


def get_sms() -> SmsProvider:
    if settings.sms_provider == "console":
        return ConsoleSms()
    raise RuntimeError(f"Fournisseur SMS inconnu : {settings.sms_provider}")
