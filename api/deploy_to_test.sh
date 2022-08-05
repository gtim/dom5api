# deploy to test server, beta.dom5api.illwiki.com
rsync --archive --verbose --recursive vendor /srv/http/beta.dom5api.illwiki.com/
rsync --archive --verbose --recursive --copy-dirlinks public_html /srv/http/beta.dom5api.illwiki.com/

