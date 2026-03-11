from pathlib import Path

ROOT_DIR = Path(__file__).resolve().parent.parent

DATA_DIR = ROOT_DIR / "data"
TRAIN_FILE = DATA_DIR / "ratings_train.txt"
TEST_FILE = DATA_DIR / "ratings_test.txt"

TFIDF_MAX_FEATURES = 10000
RANDOM_STATE = 42
TEST_SIZE = 0.2
LOGISTIC_MAX_ITER = 1000