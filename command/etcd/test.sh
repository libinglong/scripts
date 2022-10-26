CERT_DIR=/tmp/build/etcd

curl https://127.0.0.1:2379/v2/keys/foo \
  -X PUT \
  -d value=xxs \
  --cacert ${CERT_DIR}/etcd-root-ca.pem \
  --cert ${CERT_DIR}/s1.pem \
  --key ${CERT_DIR}/s1-key.pem

curl https://127.0.0.1:2379/v2/keys/foo \
  --cacert ${CERT_DIR}//etcd-root-ca.pem \
  --cert ${CERT_DIR}/s1.pem \
  --key ${CERT_DIR}/s1-key.pem