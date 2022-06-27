#!/bin/bash

#######################################
# A script autocreate of the FastAPI project structure.
# Author: Eldar
# Date: 27.06.2022
#######################################

set -e

echo "Start generate project folder"
echo "-----------------------------"

mkdir project
cd project

mkdir backend
touch docker-compose.yml .gitignore README.md

cd backend
mkdir app .venv
printf "fastapi\nuvicorn\nSQLAlchemy\nalembic\npydantic" > requirements.txt
touch Dockerfile entrypoint.sh .env .dockerignore

python3 -m pip install pipenv || python -m pip install pipenv 
pipenv install -r requirements.txt
pipenv run alembic init app/migrations
rm -rf requirements.txt

cd app
mkdir api core crud db models schemas tests
touch __init__.py main.py dependencies.py

# API folder
mkdir api/api_v1
touch api/__init__.py api/dependencies.py
touch api/api_v1/api.py api/api_v1/__init__.py
mkdir api/api_v1/endpoints
touch api/api_v1/endpoints/__init__.py

# Core folder
touch core/__init__.py core/config.py

# CRUD folder
touch crud/__init__.py

# Database folder
touch db/__init__.py db/database.py

# Models folder
touch models/__init__.py

# Schemas folder
touch schemas/__init__.py

# Tests folder
touch tests/__init__.py

# Default settings Core/config.py
printf "import secrets
import os\n
from pydantic import BaseSettings\n\n
class Settings(BaseSettings):
    # Application
    PROJECT_NAME: str = \"My API\"
    PROJECT_VERSION: str = \"1.0\"
    API_V1_STR: str = \"/api/v1\"
    SECRET_KEY: str = secrets.token_urlsafe(32)
    SQLALCHEMY_DATABASE_URI: str = \"sqlite:///db.sqlite3\"\n
settings = Settings()\n" > core/config.py

# Default Database settings
printf "from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker\n
from app.core.config import settings\n\n
engine = create_engine(settings.SQLALCHEMY_DATABASE_URI, connect_args={\"check_same_thread\": False})
local_session = sessionmaker(autocommit=False, autoflush=False, bind=engine)\n
def get_session():
    with local_session() as session:
        yield session\n" > db/database.py

# Models Examples
# Base model
printf "from sqlalchemy.ext.declarative import declarative_base\n
Base = declarative_base()\n" > models/base.py

# User simple model
printf "from sqlalchemy import Boolean, Column, Integer, String
#from sqlalchemy.orm import relationship\n
from .base import Base\n\n
class User(Base):
    __tablename__ = \"users\"\n
    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    hashed_password = Column(String)
    is_active = Column(Boolean, default=True)\n" > models/user.py

# Init all models
printf "from .base import Base\nfrom .user import User\n" > models/__init__.py

# Main Entrypoint Program
printf "from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware\n
from app.api.api_v1.api import api_router
from app.core.config import settings\n\n
app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.PROJECT_VERSION
)\n\n
app.add_middleware(
    CORSMiddleware,
    allow_origins=[\"http://localhost:8080\"],
    allow_credentials=True,
    allow_methods=[\"*\"],
    allow_headers=[\"*\"],
)\n
app.include_router(api_router, prefix=settings.API_V1_STR)\n" > main.py


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
printf "from .user import User, UserCreate\n" > schemas/__init__.py

# CRUD Example
# User CRUD
printf "from sqlalchemy.orm import Session\n
from app import models, schemas\n\n
def get_users(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.User).offset(skip).limit(limit).all()\n" > crud/user.py

# Init all CRUD functions
printf "from .user import get_users\n" > crud/__init__.py

# API Routing
# Endpoints example
printf "from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app import schemas, crud
from app.db.database import get_session\n\n
router = APIRouter()\n\n
@router.get(\"/users/\", response_model=list[schemas.User])
def read_users(skip: int = 0, limit: int = 100, db: Session = Depends(get_session)):
    users = crud.get_users(db, skip=skip, limit=limit)
    return users\n" > api/api_v1/endpoints/user.py

# Register api router
printf "from fastapi import APIRouter\n
from app.api.api_v1.endpoints import user\n
api_router = APIRouter()
api_router.include_router(user.router, prefix=\"/users\", tags=[\"users\"])\n" > api/api_v1/api.py

cd ../..
# Filling in a entrypoint file
printf "#!/bin/bash\n\nset -e\n
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000" > backend/entrypoint.sh

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
cp .gitignore backend/.dockerignore

echo "-----------------------------"
echo Finished $@
