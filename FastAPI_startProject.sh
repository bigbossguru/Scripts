#!/bin/bash

########################################################
# A script autocreate of the FastAPI project structure.
# Author: Eldar
# Date: 27.06.2022
########################################################

set -e
echo "--------------------------------------"
echo "Start generate FastAPI backend project"
echo "--------------------------------------"
mkdir backend
cd backend
mkdir app .venv
printf "fastapi\nuvicorn\nSQLAlchemy\nalembic\npydantic
python-dotenv\naiosqlite\npasslib\npython-jose
argon2-cffi\nasyncpg\npsycopg2-binary\n" > requirements.txt

python -m venv .venv
source .venv/Scripts/activate
python -m pip install -U pip
pip install -r requirements.txt

alembic init -t async migrations

# .env file
printf "DEBUG=True
POSTGRES_SERVER=localhost
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=postgres
PGADMIN_EMAIL=admin@admin.com
PGADMIN_PASSWD=root
CORS_ORIGINS=[\"*\"]
FIRST_SUPERUSER_EMAIL=admin@admin.com
FIRST_SUPERUSER_PASSWORD=admin" > .env

# generate secret_key token
python -c "import secrets; print(f'\nSECRET_KEY={secrets.token_urlsafe(64)}')" >> .env

# Filling in git and docker ignore files
printf "### Python ###
# Byte-compiled / optimized / DLL files
__pycache__/
*.py[cod]\n
# C extensions
*.so\n
# Distribution / packaging
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST\n
# PyInstaller
*.manifest
*.spec\n
# Installer logs
pip-log.txt
pip-delete-this-directory.txt\n
# Unit test / coverage reports
htmlcov/
.tox/
.nox/
.coverage
.coverage.*
.cache
nosetests.xml
coverage.xml
*.cover
*.py,cover
.hypothesis/
.pytest_cache/
cover/\n
# Translations
*.mo
*.pot\n
# Django stuff:
*.log
local_settings.py
db.sqlite3
db.sqlite3-journal\n
# Flask stuff:
instance/
.webassets-cache\n
# Scrapy stuff:
.scrapy\n
# Sphinx documentation
docs/_build/\n
# PyBuilder
.pybuilder/
target/\n
# Jupyter Notebook
.ipynb_checkpoints\n
# IPython
profile_default/
ipython_config.py\n
# pipenv
Pipfile.lock\n
# poetry
poetry.lock\n
# PEP 582; used by e.g. github.com/David-OConnor/pyflow and github.com/pdm-project/pdm
__pypackages__/\n
# Celery stuff
celerybeat-schedule
celerybeat.pid\n
# SageMath parsed files
*.sage.py\n
# Environments
.env
.venv
env/
venv/
ENV/
env.bak/
venv.bak/\n
# Spyder project settings
.spyderproject
.spyproject\n
# Rope project settings
.ropeproject\n
# mkdocs documentation
/site\n
# mypy
.mypy_cache/
.dmypy.json
dmypy.json\n
# Pyre type checker
.pyre/\n
# pytype static type analyzer
.pytype/\n
# Cython debug symbols
cython_debug/\n
# PyCharm and VScode
.idea/
.vscode/" > .gitignore

printf "# The automatic generated a FastAPI project structure\n
## Quick start\n
### Activate virtual environment\n
\`\`\`\ncd backend\npipenv shell\n\`\`\`\n
### Create and migrate database using Alembic commands\n
\`\`\`\npipenv run alembic revision --autogenerate -m \"init database\"\npipenv run alembic upgrade head\n\`\`\`\n
### Start FastAPI server\n
\`\`\`\npipenv run uvicorn app.main:app --reload --host 0.0.0.0 --port 8000\n\`\`\`\n
" > README.md

cd app
mkdir api core database models schemas services security
touch __init__.py main.py

# API folder
mkdir api/v1
touch api/__init__.py api/deps.py api/api.py
touch api/v1/__init__.py

# Core folder
touch core/__init__.py core/config.py

# Database folder
touch database/__init__.py database/connection.py

# Models folder
touch models/__init__.py

# Schemas folder
touch schemas/__init__.py

# Services folder
touch services/__init__.py

# Default settings Core/config.py
printf "from typing import List, Union
from pydantic import BaseSettings, validator\n
class Config(BaseSettings):
    PROJECT_NAME: str = \"Unknown FARP\"
    PROJECT_VERSION: str = \"0.0.1\"
    PROJECT_DESCRIPTION: str = \"A simple REST API proxy\"

    SECRET_KEY: str
    DEBUG: bool = False

    # 60 minutes * 24 hours * 8 days = 8 days
    ACCESS_TOKEN_EXPIRY_TIME: int = 60 * 24 * 8
    ALGORITHM: str = \"HS256\"

    # Database settings
    POSTGRES_SERVER: str
    POSTGRES_USER: str
    POSTGRES_PASSWORD: str
    POSTGRES_DB: str

    FIRST_SUPERUSER_EMAIL: str
    FIRST_SUPERUSER_PASSWORD: str

    CORS_ORIGINS: List[str] = [\"*\"]

    @validator(\"CORS_ORIGINS\", pre=True)
    def assemble_cors_origins(cls, v: Union[str, List[str]]) -> Union[List[str], str]:
        if isinstance(v, str) and not v.startswith(\"[\"):
            return [i.strip() for i in v.split(\",\")]
        if isinstance(v, (list, str)):
            return v
        raise ValueError(v)

    class Config:
        env_file = \".env\"
        env_file_encoding = \"utf-8\"

conf = Config()
" > core/config.py

# Default Database settings
printf "from sqlalchemy.orm import sessionmaker, declarative_base
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession\n
from app.core.config import conf

DATABASE_URL = \"sqlite+aiosqlite:///./database.db\"

Base = declarative_base()

engine = create_async_engine(DATABASE_URL, future=True, echo=conf.DEBUG)
async_session = sessionmaker(engine, expire_on_commit=False, class_=AsyncSession)\n

async def get_session():
    async with async_session() as session:
        yield session
" > database/connection.py

# Models Examples
# User simple model
printf "from sqlalchemy import Boolean, Column, Integer, String
#from sqlalchemy.orm import relationship\n
from app.database.connection import Base\n\n
class User(Base):
    __tablename__ = \"users\"\n
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)\n" > models/user.py

# Init all models
printf "from .user import *\n" > models/__init__.py

# Main Entrypoint Program
printf "from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware\n
from app.api.api import api_router
from app.core.config import conf\n\n
app = FastAPI(
    title=conf.PROJECT_NAME,
	description=conf.PROJECT_DESCRIPTION,
    version=conf.PROJECT_VERSION
)\n\n
app.add_middleware(
    CORSMiddleware,
    allow_origins=conf.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=[\"*\"],
    allow_headers=[\"*\"],
)\n
app.include_router(api_router)\n" > main.py


# Schemas Example
# User schema
printf "from pydantic import BaseModel\n
class UserBase(BaseModel):
    email: str\n
class UserCreate(UserBase):
    password: str\n
class User(UserBase):
    id: int
    is_active: bool\n
    class Config:
        orm_mode = True" > schemas/user.py

# Init all schemas
printf "from .user import *\n" > schemas/__init__.py

# Register api router
printf "from fastapi import APIRouter\n
#from app.api.v1 import user\n
api_router = APIRouter()
#api_router.include_router(user.router, prefix=\"/users\", tags=[\"users\"])\n" > api/api.py

# Security Auth basic class
printf "from .auth import Auth\n" > security/__init__.py
printf "from typing import Optional
from datetime import datetime, timedelta

from pydantic import EmailStr
from fastapi import HTTPException, status
from passlib.context import CryptContext
from jose import jwt
from jose.exceptions import ExpiredSignatureError, JWTError

from app.core.config import conf


class Auth:
    pwd_context = CryptContext(schemes=[\"argon2\"], deprecated=\"auto\")

    def verify_password(self, plain_password: str, hashed_password: str) -> bool:
        return self.pwd_context.verify(plain_password, hashed_password)

    def get_password_hash(self, password: str) -> str:
        return self.pwd_context.hash(password)

    def encode_token(self, email: EmailStr, expires_delta: Optional[timedelta] = None) -> str:
        if expires_delta:
            expire = datetime.utcnow() + expires_delta
        else:
            expire = datetime.utcnow() + timedelta(minutes=conf.ACCESS_TOKEN_EXPIRY_TIME)
        payload = {\"exp\": expire, \"iat\": datetime.utcnow(), \"scope\": \"access_token\", \"sub\": email}
        return jwt.encode(payload, conf.SECRET_KEY, algorithm=conf.ALGORITHM)

    def decode_token(self, token: str) -> EmailStr:
        try:
            payload = jwt.decode(token=token, key=conf.SECRET_KEY, algorithms=conf.ALGORITHM)
            if payload[\"scope\"] == \"access_token\":
                return payload[\"sub\"]
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=\"Scope for the token is invalid\")
        except ExpiredSignatureError:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=\"Token expired\")
        except JWTError:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=\"Invalid token\")
" > security/auth.py

echo "-----------------------------"
echo Finished $@
echo "-----------------------------"