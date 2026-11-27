from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", extra="ignore")

    mongo_uri: str = "mongodb://localhost:27017"
    mongo_db: str = "newsapp"
    retention_days: int = 14  # Atlas M0 has 512 MB: keep it short
    summary_words: int = 60
    cors_origins: str = "*"


settings = Settings()
