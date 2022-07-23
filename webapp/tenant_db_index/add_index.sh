rm *.db
cp -r ../../initial_data/*.db ./
for var in `ls -1 *.db`
do
  echo $var
  cat ../add_inedx.sql | sqlite3 $var
done

