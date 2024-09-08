if [ "${SHARE}" ]; then
    ls -al
    echo ${SHARE}
    echo "Sync Share"
    mv bitcoin.zip ${SHARE}/bitcoin.zip
fi

echo "Finish Bundle"