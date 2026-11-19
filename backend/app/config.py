from pydantic_settings import BaseSettings, SettingsConfigDict

_DEV_SECRETS = {"dev-only-change-me", "dev-only-change-me-too"}


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="TCHIHALI_", extra="ignore")

    env: str = "dev"
    database_url: str = "postgresql://tchihali:tchihali@127.0.0.1:55432/tchihali"
    jwt_secret: str = "dev-only-change-me"
    otp_secret: str = "dev-only-change-me-too"
    access_ttl_min: int = 15
    refresh_ttl_days: int = 30
    sms_provider: str = "console"
    dev_return_code: bool = False
    payment_provider: str = "simulated"
    cors_origins: str = ""

    def check_production(self) -> None:
        """Refuse de démarrer en production avec une configuration dangereuse."""
        if self.env == "dev":
            return
        problems = []
        if self.jwt_secret in _DEV_SECRETS or self.otp_secret in _DEV_SECRETS:
            problems.append("secrets JWT/OTP par défaut")
        if len(self.jwt_secret) < 32 or len(self.otp_secret) < 32:
            problems.append("secrets trop courts (32 caractères minimum)")
        if self.dev_return_code:
            problems.append("TCHIHALI_DEV_RETURN_CODE doit être false")
        if self.sms_provider == "console":
            problems.append("aucun fournisseur SMS réel configuré")
        if problems:
            raise RuntimeError("Configuration de production refusée : " + ", ".join(problems))


settings = Settings()
