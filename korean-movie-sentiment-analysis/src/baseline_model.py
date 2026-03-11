from sklearn.model_selection import train_test_split
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score

def train_baseline(df):
    # train/validation split
    X_train, X_val, y_train, y_val = train_test_split(
        df["document"],
        df["label"],
        test_size=0.2,
        random_state=42
    )
    # TF-IDF 벡터화
    vectorizer = TfidfVectorizer(max_features=10000)
    X_train_vec = vectorizer.fit_transform(X_train)
    X_val_vec = vectorizer.transform(X_val)

    model = LogisticRegression(max_iter=1000)
    model.fit(X_train_vec, y_train)

    # validation accuracy
    pred = model.predict(X_val_vec)
    acc = accuracy_score(y_val, pred)

    return model, vectorizer, acc