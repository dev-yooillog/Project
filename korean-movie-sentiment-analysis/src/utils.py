import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.metrics import confusion_matrix

def plot_confusion_matrix(y_true, y_pred, labels=[0,1], title="Confusion Matrix"):
    cm = confusion_matrix(y_true, y_pred, labels=labels)
    plt.figure(figsize=(6,5))
    sns.heatmap(cm, annot=True, fmt="d", cmap="Blues")
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.title(title)
    plt.show()

def predict_samples(model, vectorizer, texts):
    X_vec = vectorizer.transform(texts)
    pred = model.predict(X_vec)
    result = ["긍정" if p==1 else "부정" for p in pred]
    return list(zip(texts, result))