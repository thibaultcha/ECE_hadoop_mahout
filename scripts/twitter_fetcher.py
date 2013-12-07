#
# Copyright (c) 2010 the original author or authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

import tweepy
import sys

CONSUMER_KEY='m1QO3jc9OceRMQWoQFwM3w'
CONSUMER_SECRET='vCOX1s4IoZ8dR1zVoMSGDAJFlsj1eRzhf9n40bMkd4'
ACCESS_TOKEN_KEY='135171557-xRqabVZv4aBESIz38FKj5vp0XLmoTrl1dueymmNs'
ACCESS_TOKEN_SECRET='wYuHPHpwZaLsCye5ZtzBd0kRm4nEq3lWOqw5dmvDXY'

auth = tweepy.OAuthHandler(CONSUMER_KEY, CONSUMER_SECRET)
auth.set_access_token(ACCESS_TOKEN_KEY, ACCESS_TOKEN_SECRET)
api = tweepy.API(auth)

pageCount = 5
if len(sys.argv) >= 2:
	pageCount = int(sys.argv[1])
hashtags = ['edf']

for tag in hashtags:
	maxId = 999999999999999999999
	for i in range(1, pageCount + 1):
		results = api.search(q='#%s' % tag, max_id=maxId, count=100)
		print len(results)
		for result in results:
			maxId = min(maxId, result.id)
			print "%s" % (result.text.encode('utf-8').replace('\n', ' '))
