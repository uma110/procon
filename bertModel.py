from torch import nn
from transformers.modeling_bert import BertModel

# BERTの日本語学習済みパラメータのモデルです
model = BertModel.from_pretrained('bert-base-japanese-whole-word-masking')
print(model)

class BertForLivedoor(nn.Module):
    def __init__(self):
        super(BertForLivedoor,self).__init__()
        self.bert = model
        self.cls = nn.Linear(in_features=768, out_features=9)

        # 重み初期化処理
        nn.init.normal_(self.cls.weight, std=0.02)
        nn.init.normal_(self.cls.bias, 0)

    def forward(self,input_ids):
        result = self.bert(input_ids)

        vec_0 = result[0]
        vec_0 = vec_0[:,0,:]
        vec_0 = vec_0.view(-1,768)

        output = self.cls(vec_0)
        return output