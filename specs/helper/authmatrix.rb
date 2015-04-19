require_relative '../../lib/models/user'
require_relative '../../lib/models/channel'
require_relative '../../lib/models/permission'
include Logformat

# Test access matrix
#   | u1 | u2 | anon
# --|----|----|------
# c1| ?  | N  | ?
# c2| Y  | D  | D
# c3| Y  | ?  | D
#
# where ? = no rule, D = DEFAULT rule, Y = allowed, N = not allowed

u1 = User.create(:name => 'user1', :password => 'pass1', :password_confirmation => 'pass1')
u2 = User.create(:name => 'user2', :password => 'pass2', :password_confirmation => 'pass2')
c1 = Channel.create(:name => '#channel1')
c2 = Channel.create(:name => '#channel2')
c3 = Channel.create(:name => '#channel3')
c1.deny!(u2)
c2.allow!(u1)
Permission.create(:user => u2, :channel => c2, :rule => Permission::DEFAULT)
c2.deny_anonymous!
c3.allow!(u1)
c3.deny_anonymous!
