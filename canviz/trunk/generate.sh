#!/bin/sh

INSTALL_DIR=/usr/local/graphviz
TEMP_GRAPH=`mktemp -t canviz`
TEMP_HEADER=`mktemp -t canviz`
DOT_VERSION=`$INSTALL_DIR/bin/dot -V 2>&1`
OUTPUT_GRAPHS=./graphs

echo "Generating with $DOT_VERSION"
for PROGRAM in dot neato fdp circo twopi; do
	mkdir -p $OUTPUT_GRAPHS/$PROGRAM
	for FILE_PATH in $INSTALL_DIR/share/graphviz/graphs/directed/*.dot $INSTALL_DIR/share/graphviz/graphs/undirected/*.dot; do
		FILE_NAME=`basename $FILE_PATH`
		echo -n $PROGRAM -Txdot $FILE_NAME
		(time $INSTALL_DIR/bin/$PROGRAM -Txdot $FILE_PATH > $TEMP_GRAPH) 2> $TEMP_HEADER
		if [ -s $TEMP_GRAPH ]; then
			NOW=`TZ=GMT date`
			echo "# Generated $NOW by $DOT_VERSION" > $OUTPUT_GRAPHS/$PROGRAM/$FILE_NAME
			echo '#' >> $OUTPUT_GRAPHS/$PROGRAM/$FILE_NAME
			sed 's/^/# /' < $TEMP_HEADER >> $OUTPUT_GRAPHS/$PROGRAM/$FILE_NAME
			echo >> $OUTPUT_GRAPHS/$PROGRAM/$FILE_NAME
			cat $TEMP_GRAPH >> $OUTPUT_GRAPHS/$PROGRAM/$FILE_NAME
			echo
		else
			echo ' - CRASHED!'
		fi
	done
done
rm -f $TEMP_GRAPH $TEMP_HEADER
