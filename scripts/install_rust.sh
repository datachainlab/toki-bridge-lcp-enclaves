cd $HOME && \
curl 'https://static.rust-lang.org/rustup/dist/x86_64-unknown-linux-gnu/rustup-init' --output $HOME/rustup-init && \
chmod +x $HOME/rustup-init && \
echo '1' | $HOME/rustup-init --default-toolchain ${rust_toolchain} && \
echo 'source $HOME/.cargo/env' >> $HOME/.bashrc && \
$HOME/.cargo/bin/rustup component add rust-src rls rust-analysis clippy rustfmt && \
$HOME/.cargo/bin/cargo install xargo && \
rm $HOME/rustup-init && rm -rf $HOME/.cargo/registry && rm -rf $HOME/.cargo/git
