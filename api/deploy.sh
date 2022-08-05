# deploy to production
rsync --archive --verbose --recursive vendor /srv/http/dom5api.illwiki.com/
rsync --archive --verbose --recursive --copy-dirlinks public_html /srv/http/dom5api.illwiki.com/
