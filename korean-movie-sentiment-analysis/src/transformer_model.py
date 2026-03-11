from transformers import AutoTokenizer
from transformers import AutoModelForSequenceClassification

def load_model():

    model_name = "klue/roberta-base"
    tokenizer = AutoTokenizer.from_pretrained(model_name)
    model = AutoModelForSequenceClassification.from_pretrained(
        model_name,
        num_labels=2
    )
    return tokenizer, model