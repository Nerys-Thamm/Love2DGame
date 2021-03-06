echo -n "Enter Game Name:";
read NAME;
cd ..;
zip -9 -r ./release/$NAME.love *.lua assets sti;
cat ./release/love.exe ./release/$NAME.love > ./release/$NAME.exe;
cd release;
zip "${NAME}_release.zip" $NAME.exe *.dll README.txt;
rm $NAME.exe;
rm $NAME.love;
echo "Done!";
read -p "Press [Enter] key to exit...";
