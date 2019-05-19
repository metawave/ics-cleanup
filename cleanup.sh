#!/bin/bash

# Must give filename
if [ -z "$1" ]; then
  echo "No argument supplied"
  exit 1
fi

# Check prequisites
PERL_FOUND=`which perl`
if [ -z $PERL_FOUND ];
then
  echo perl not found or not in PATH
  exit 1
fi
SED_FOUND=`which sed`
if [ -z $SED_FOUND ];
then
  echo sed not found or not in PATH
  exit 1
fi

# DEBUG: RESTORE ORIGINAL FILE
# cp *.backup $1 && rm -f *.backup

# Create backup
cp $1 "$1.$(date "+%Y%m%d-%H%M%S%s").backup"

# Remove X Tokens
#
# The Format is extensible with X- prefixed values, depending on the app, it's safe to remove those, 
# if you transfer from one software to another, but can be helpful if you export and import it in the same kind of software
perl -0777 -pi -e 's/^X-.*$//mg' $1
# if you only whish to remove microsoft tokens:
# perl -0777 -pie 's/^X-.*$//mg' $1

# Remove Product ID
#
# Information in which program you've exported the calendar
perl -0777 -pi -e 's/^PRODID:.*$//mg' $1

# Remove Timezone (VTIMEZONE)
#
# This might only be needed if you're in a custom timezone or a calendar should have a specific timezone, sometimes
# this confuses applications if you've already set a timezone on a calendar and want to import it in another way.
perl -0777 -pi -e 's/BEGIN:VTIMEZONE(.|\n)*?END:VTIMEZONE//mg' $1

# Remove UID's
#
# Sometimes calendar exports (faulty ones) get same UID's for the same event, so remove UIDs completely
perl -0777 -pi -e 's/^UID:.*$//mg' $1

# Remove SEQUENCE
#
# This flags each component on which revision this item is, example: an organizer edits the time, the sequence is then incremented
# for exports we don't need that component anymore (at least sometimes).
perl -0777 -pi -e 's/^SEQUENCE:.*$//mg' $1

# Remove DTSTAMP
#
# Like SEQUENCE this is used to determine which calendar entry overwrites the other in the case of conflicts. In an export/import we might not need this
perl -0777 -pi -e 's/^DTSTAMP:.*$//mg' $1

# Remove created
#
# The information when an item was created is not important for importing
perl -0777 -pi -e 's/^CREATED:.*$//mg' $1

# Remove TRANSP
#
# Required if free/busy is implemented, don't see the need for that
perl -0777 -pi -e 's/^TRANSP:.*$//mg' $1

# Remove Alarms
#
# In case if you want to remove all alarms on all events, you can enable this line (but you don't want to do that normally, but can be useful)
# perl -0777 -pi -e 's/BEGIN:VALARM(.|\n)*?END:VALARM//mg' $1

# Remove Conference Links
#
# This might be a extension of Outlook, where one can add conference details to the event
perl -0777 -pi -e 's/^CONFERENCE;.*$//mg' $1

# Remove empty lines
sed -i "" '/^[[:space:]]*$/d' "$1"