#! /bin/sh 

#Download and Initialize the client
sudo apt-get update
cd /home/ubuntu
curl -LOJ https://github.com/crypto-org-chain/chain-main/releases/download/v1.2.1/chain-main_1.2.1_Linux_x86_64.tar.gz
sudo tar -zxvf chain-main_1.2.1_Linux_x86_64.tar.gz
mv /home/ubuntu/bin/chain-maind /usr/local/bin/
sudo chain-maind init akaroth --chain-id crypto-org-chain-mainnet-1
curl https://raw.githubusercontent.com/crypto-org-chain/mainnet/main/crypto-org-chain-mainnet-1/genesis.json > /root/.chain-maind/config/genesis.json
sed -i.bak -E 's#^(minimum-gas-prices[[:space:]]+=[[:space:]]+)""$#\1"0.025basecro"#' /root/.chain-maind/config/app.toml
sed -i.bak -E 's#^(seeds[[:space:]]+=[[:space:]]+).*$#\1"8dc1863d1d23cf9ad7cbea215c19bcbe8bf39702@p2p.baaa7e56-cc71-4ae4-b4b3-c6a9d4a9596a.cryptodotorg.bison.run:26656,494d860a2869b90c458b07d4da890539272785c9@p2p.fabc23d9-e0a1-4ced-8cd7-eb3efd6d9ef3.cryptodotorg.bison.run:26656,8a7922f3fb3fb4cfe8cb57281b9d159ca7fd29c6@p2p.aef59b2a-d77e-4922-817a-d1eea614aef4.cryptodotorg.bison.run:26656,dc2540dabadb8302da988c95a3c872191061aed2@p2p.7d1b53c0-b86b-44c8-8c02-e3b0e88a4bf7.cryptodotorg.herd.run:26656,33b15c14f54f71a4a923ac264761eb3209784cf2@p2p.0d20d4b3-6890-4f00-b9f3-596ad3df6533.cryptodotorg.herd.run:26656,d2862ef8f86f9976daa0c6f59455b2b1452dc53b@p2p.a088961f-5dfd-4007-a15c-3a706d4be2c0.cryptodotorg.herd.run:26656,87c3adb7d8f649c51eebe0d3335d8f9e28c362f2@seed-0.crypto.org:26656,e1d7ff02b78044795371beb1cd5fb803f9389256@seed-1.crypto.org:26656,2c55809558a4e491e9995962e10c026eb9014655@seed-2.crypto.org:26656"#' /root/.chain-maind/config/config.toml
sed -i.bak -E 's#^(create_empty_blocks_interval[[:space:]]+=[[:space:]]+).*$#\1"5s"#' /root/.chain-maind/config/config.toml

sudo su -

#Create the systemctl file
cat <<EOF >>/etc/systemd/system/chain-maind.service
[Unit]
Description=Chain-maind
ConditionPathExists=/usr/local/bin/chain-maind
After=network.target

[Service]
Type=simple
User=root 
WorkingDirectory=/usr/local/bin
ExecStart=chain-maind start --home /root/.chain-maind
Restart=on-failure
RestartSec=10
LimitNOFILE=4096

[Install]
WantedBy=multi-user.target
EOF

#Start the service
sudo systemctl start chain-maind

#Stop the client after designated height and start with new client version
cat <<EOF >>/root/restart_new_client.sh
systemctl stop chain-maind
curl -LOJ https://github.com/crypto-org-chain/chain-main/releases/download/v2.1.2/chain-main_2.1.2_Linux_x86_64.tar.gz
tar -zxvf chain-main_2.1.2_Linux_x86_64.tar.gz
rm -rf /usr/local/bin/chain-maind
mv /root/bin/chain-maind /usr/local/bin/
systemctl start chain-maind
EOF

