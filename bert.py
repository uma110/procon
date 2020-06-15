import torch
import torchtext  # torchtextを使用
from transformers.modeling_bert import BertModel
from transformers.tokenization_bert_japanese import BertJapaneseTokenizer

import random

# 日本語BERTの分かち書き用tokenizerです
tokenizer = BertJapaneseTokenizer.from_pretrained(
    'bert-base-japanese-whole-word-masking')

    # データを読み込んだときに、読み込んだ内容に対して行う処理を定義します

max_length = 512  # 東北大学_日本語版の最大の単語数（サブワード数）は512


def tokenizer_512(input_text):
    """torchtextのtokenizerとして扱えるように、512単語のpytorchでのencodeを定義。ここで[0]を指定し忘れないように"""
    return tokenizer.encode(input_text, max_length=512, return_tensors='pt')[0]


TEXT = torchtext.data.Field(sequential=True, tokenize=tokenizer_512, use_vocab=False, lower=False,
                            include_lengths=True, batch_first=True, fix_length=max_length, pad_token=0)
# 注意：tokenize=tokenizer.encodeと、.encodeをつけます。padding[PAD]のindexが0なので、0を指定します。

LABEL = torchtext.data.Field(sequential=False, use_vocab=False)

# (注釈)：各引数を再確認
# sequential: データの長さが可変か？文章は長さがいろいろなのでTrue.ラベルはFalse
# tokenize: 文章を読み込んだときに、前処理や単語分割をするための関数を定義
# use_vocab：単語をボキャブラリーに追加するかどうか
# lower：アルファベットがあったときに小文字に変換するかどうか
# include_length: 文章の単語数のデータを保持するか
# batch_first：ミニバッチの次元を用意するかどうか
# fix_length：全部の文章をfix_lengthと同じ長さになるように、paddingします
# init_token, eos_token, pad_token, unk_token：文頭、文末、padding、未知語に対して、どんな単語を与えるかを指定

# 各tsvファイルを読み込み、分かち書きをしてdatasetにします
# 少し時間がかかります
# train_eval：5901個、test：1475個
dataset_train_eval, dataset_test = torchtext.data.TabularDataset.splits(
    path='.', train='train_eval.tsv', test='test.tsv', format='tsv', fields=[('Text', TEXT), ('Label', LABEL)])

# torchtext.data.Datasetのsplit関数で訓練データと検証データを分ける
# train_eval：5901個、test：1475個

dataset_train, dataset_eval = dataset_train_eval.split(
    split_ratio=1.0 - 1475/5901, random_state=random.seed(1234))

# datasetの長さを確認してみる
print(dataset_train.__len__())
print(dataset_eval.__len__())
print(dataset_test.__len__())

# datasetの中身を確認してみる
item = next(iter(dataset_train))
print(item.Text)
print("長さ：", len(item.Text))  # 長さを確認 [CLS]から始まり[SEP]で終わる。512より長いと後ろが切れる
print("ラベル：", item.Label)

# datasetの中身を文章に戻し、確認

print(tokenizer.convert_ids_to_tokens(item.Text.tolist()))  # 文章
# dic_id2cat[int(item.Label)]  # id

# DataLoaderを作成します（torchtextの文脈では単純にiteraterと呼ばれています）
batch_size = 16  # BERTでは16、32あたりを使用する

dl_train = torchtext.data.Iterator(
    dataset_train, batch_size=batch_size, train=True)

dl_eval = torchtext.data.Iterator(
    dataset_eval, batch_size=batch_size, train=False, sort=False)

dl_test = torchtext.data.Iterator(
    dataset_test, batch_size=batch_size, train=False, sort=False)

# 辞書オブジェクトにまとめる
dataloaders_dict = {"train": dl_train, "val": dl_eval}

import bertModel

net = bertModel.BertForLivedoor()

print(net)
net.train()

print("network setting completed")

for param in net.parameters():
    param.requires_grad = False

for param in net.bert.encoder.layer[-1].parameters():
    param.requires_grad = True

for param in net.cls.parameters():
    param.requires_grad = True

import torch.optim as optim

optimizer = optim.Adam([
    {'params': net.bert.encoder.layer[-1].parameters(), 'lr':5e-5},
    {'params': net.cls.parameters(), 'lr':1e-4}
])

from torch import nn
criterion = nn.CrossEntropyLoss()

def train_model(net, dataloaders_dict, criterion, optimizer, num_epochs):
    
    # GPUが使えるかを確認
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print("使用デバイス：", device)
    print('-----start-------')

    # ネットワークをGPUへ
    net.to(device)

    # ネットワークがある程度固定であれば、高速化させる
    torch.backends.cudnn.benchmark = True

    # ミニバッチのサイズ
    batch_size = dataloaders_dict["train"].batch_size

    # epochのループ
    for epoch in range(num_epochs):
        # epochごとの訓練と検証のループ
        for phase in ['train', 'val']:
            if phase == 'train':
                net.train()  # モデルを訓練モードに
            else:
                net.eval()   # モデルを検証モードに

            epoch_loss = 0.0  # epochの損失和
            epoch_corrects = 0  # epochの正解数
            iteration = 1

            # データローダーからミニバッチを取り出すループ
            for batch in (dataloaders_dict[phase]):
                # batchはTextとLableの辞書型変数

                # GPUが使えるならGPUにデータを送る
                inputs = batch.Text[0].to(device)  # 文章
                labels = batch.Label.to(device)  # ラベル

                # optimizerを初期化
                optimizer.zero_grad()

                # 順伝搬（forward）計算
                with torch.set_grad_enabled(phase == 'train'):

                    # BERTに入力
                    outputs = net(inputs)

                    loss = criterion(outputs, labels)  # 損失を計算

                    _, preds = torch.max(outputs, 1)  # ラベルを予測

                    # 訓練時はバックプロパゲーション
                    if phase == 'train':
                        loss.backward()
                        optimizer.step()

                        if (iteration % 10 == 0):  # 10iterに1度、lossを表示
                            acc = (torch.sum(preds == labels.data)
                                   ).double()/batch_size
                            print('イテレーション {} || Loss: {:.4f} || 10iter. || 本イテレーションの正解率：{}'.format(
                                iteration, loss.item(),  acc))

                    iteration += 1

                    # 損失と正解数の合計を更新
                    epoch_loss += loss.item() * batch_size
                    epoch_corrects += torch.sum(preds == labels.data)

            # epochごとのlossと正解率
            epoch_loss = epoch_loss / len(dataloaders_dict[phase].dataset)
            epoch_acc = epoch_corrects.double(
            ) / len(dataloaders_dict[phase].dataset)

            print('Epoch {}/{} | {:^5} |  Loss: {:.4f} Acc: {:.4f}'.format(epoch+1, num_epochs,
                                                                           phase, epoch_loss, epoch_acc))

    model_patb = 'livedoor_trained_model.pth'
    torch.save(net.state_dict(),model_patb)
    return net

num_epochs = 5
net_trained = train_model(net,dataloaders_dict,criterion,optimizer,num_epochs)