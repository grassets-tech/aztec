# GENERATE KEYSTORE

- Run script to generate keys

```
./generate_keystores_mainnet.sh 10
```

It will store files in: /home/aztec/.aztec/keystore/mainnet/operator/

- Insert Publisher and Coinbase wallet:

```
./insert_publisher_coinbase_mainnet.sh  ~/.aztec/keystore/mainnet/operator
```

- Run script to merge json for dashboard:

```
./merge_staker_outputs.sh /home/aztec/.aztec/keystore/testnet/operator/
```

It will generate merged_staker_outputs.json


- Run script to prepare cast tx:
```
./aztec-add-keys-to-provider-mainnet.sh merged_staker_outputs.json 
```
Run cast from output above:
```
cast ...
```
