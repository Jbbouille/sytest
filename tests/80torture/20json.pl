# Test integers that are outside of the range of [-2 ^ 53 + 1, 2 ^ 53 - 1].
test "Invalid JSON integers",
   requires => [ local_user_and_room_fixtures(
      room_opts => { room_version => "6" }
   ), ],

   do => sub {
      my ( $user, $room_id ) = @_;

      Future->needs_all(
         do_request_json_for( $user,
            method  => "POST",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => 9007199254740992,  # 2 ** 53
            },
         )->followed_by( \&main::expect_http_400 ),

         do_request_json_for( $user,
            method  => "PUT",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => -9007199254740992,  # -2 ** 53
            },
         )->followed_by( \&main::expect_http_400 ),
      );
   };

# Floats (including NaN, Infinity, and -Infinity) should be rejected.
test "Invalid JSON floats",
   requires => [ local_user_and_room_fixtures(
      room_opts => { room_version => "6" }
   ), ],

   do => sub {
      my ( $user, $room_id ) = @_;

      Future->needs_all(
         do_request_json_for( $user,
            method  => "POST",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => 1.1,
            },
         )->followed_by( \&main::expect_http_400 ),

         do_request_json_for( $user,
            method  => "PUT",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => "NaN",
            },
         )->followed_by( \&main::expect_http_400 ),

         do_request_json_for( $user,
            method  => "PUT",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => "inf",
            },
         )->followed_by( \&main::expect_http_400 ),

         do_request_json_for( $user,
            method  => "PUT",
            uri     => "/r0/rooms/$room_id/send/sytest.dummy",
            content => {
               msgtype => "sytest.dummy",
               body    => "-inf",
            },
         )->followed_by( \&main::expect_http_400 ),
      );
   };