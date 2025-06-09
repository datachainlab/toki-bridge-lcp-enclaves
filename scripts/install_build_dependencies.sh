set -ex

short_version=$(echo $INTEL_SGX_SDK_VERSION | cut -d. -f1,2)

SDK_URL="https://download.01.org/intel-sgx/sgx-linux/$short_version/distro/ubuntu24.04-server/sgx_linux_x64_sdk_$INTEL_SGX_SDK_VERSION.bin"

cd /root && \
curl -o sdk.sh $SDK_URL && \
chmod a+x /root/sdk.sh && \
echo -e 'no\n/opt' | ./sdk.sh && \
echo 'source /opt/sgxsdk/environment' >> /root/.bashrc && \
cd /root && \
rm ./sdk.sh
