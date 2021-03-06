#! /bin/dash

# This provides headers to a wrapper script I use for some cronjobs.
# It sends an email if the job exits non-zero, and otherwise discards
# all output.
cat <<EOF
From: "CPAN Once a Week" <>
Subject: Problem updating website

EOF

MYDIR="$(dirname "$(readlink -f "$0")")"

cd "$MYDIR" || exit 1

# Fetch new releases and update chains:
./fetchReleases.pl

case $? in
 212) ;;                        # No new releases

 0) ./makeweb.pl || exit 1      # New releases, update website
    ./mirror.sh  || exit 1
    ;;

 *)   exit 1 ;;
esac

# Commit release data to Git once a day:
if [ $(date -u '+%H') -eq 0 ] ; then
  ./backup.pl            || exit 1
  ./data/commit.pl       || exit 1
  cd data                || exit 1
  git push github master || exit 1
fi

exit 0
