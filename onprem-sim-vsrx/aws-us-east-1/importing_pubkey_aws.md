# Importing your public key to aws using aws cli

AWS expects the key to be base64 encoded. 
**Converting public key to base64 encoded**
```
cat .ssh/id_rsa.pub | base64
```
**Importing your public key to aws to a particular region**

```sh
$ aws ec2 import-key-pair --key-name "qmar-personal-mbp-key" --public-key-material "paste base 64 encoded key here" --region us-east-1
{
    "KeyFingerprint": "58:0a:5d:10:85:ef:43:b2:2e:cc:74:66:8d:3e:2e:c0",
    "KeyName": "qmar-personal-mbp-key",
    "KeyPairId": "key-0b0c978f4a9980183"
}
```
**Viewing your keys** 

```sh
$ aws ec2 describe-key-pairs --region ap-northeast-2 | jq -c '.KeyPairs[] | select(.KeyName | contains("qmar")) ' | jq .
{
  "KeyPairId": "key-0b0c978f4a9980183",
  "KeyFingerprint": "58:0a:5d:10:85:ef:43:b2:2e:cc:74:66:8d:3e:2e:c0",
  "KeyName": "qmar-personal-mbp-key",
  "KeyType": "rsa",
  "Tags": []
}
```

