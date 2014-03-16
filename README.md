##Deep Roots
This was my project for the March 2014 Cloud Foundry company hackathon.

Deep Roots is a proof of concept proxy for the Cloud Controller. The goal is to demonstrate that a request to CC with inline-relations-depth >= 1 can be decomposed into multiple requests with no inline-relations-depth, and the results recomposed into a single correct response. A proxy of this kind would simplify CC and potentially allow us to break CC into multiple components, whether for an incremental rewrite or to split it along lines of responsibility (runtime vs services, for example).

###How to use it

First, a warning: Take care in running this against a shared CF deploy, as it makes many requests. I recommend running it against a bosh-lite deploy or, for more realistic data, a CI environment.

In one terminal...
```sh
bundle install
bundle exec rackup
```

In another terminal...
```sh
cf api <api url of your cloud foundry>
export CF_USER=<the email of your test account>
export CF_PASSWORD=<the password of your test account>

# to see the response from the proxy
bin/curl_proxy /v2/apps?inline-relations-depth=1

# to test the proxy's response against the original CC's response
bin/diff /v2/apps?inline-relations-depth=1

# to test the proxy's response for many common CC endpoints
bin/diff_all
```
