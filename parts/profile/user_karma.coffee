# if Meteor.isClient
#     Template.karma_transaction.onCreated ->
#         console.log @
#
#     Template.karma_transaction.helpers
#         requests: ->
#             Docs.find {model:'shift_change_request'},
#                 sort: date: -1
#
#
#     Template.karma_transaction.events
#         'click .offer_karma': (e,t)->
#             val = parseInt t.$('.offer_karma_amount').val()
#             Docs.insert
#                 model:'offer'
#
#
#     Template.user_karma.onCreated ->
#         @autorun => Meteor.subscribe 'doc', Session.get('sending_karma')
#     Template.user_karma.events
#         'click .send_new': ->
#             new_transaction_id =
#                 Docs.insert
#                     model:'karma_transaction'
#             Session.set 'sending_karma', new_transaction_id
#
#         'click .cancel_sending': ->
#             Docs.remove Session.get('sending_karma')
#             Session.set 'sending_karma', null
#
#         'click .complete_sending': ->
#             if confirm 'confirm send karma?'
#                 transaction_doc = Docs.findOne Session.get('sending_karma')
#                 Docs.update Session.get('sending_karma'),
#                     $set:
#                         recipient:Router.current().params.username
#                         confirmed:true
#                 amount = transaction_doc.karma_amount
#                 console.log amount
#                 Meteor.users.update Meteor.userId(),
#                     $inc:karma:-amount
#                 recipient = Meteor.users.findOne username:Router.current().params.username
#                 Meteor.users.update recipient._id,
#                     $inc:karma:amount
#                 Session.set 'sending_karma', null
#
#     Template.user_karma.helpers
#         sending_karma: -> Session.get 'sending_karma'
#         send_karma_transaction: ->
#             Docs.findOne(Session.get('sending_karma'))
#
#
#
#
#
#     Template.add_karma_amount.onRendered ->
#         if Meteor.isDevelopment
#             pub_key = Meteor.settings.public.stripe_test_publishable
#         else if Meteor.isProduction
#             pub_key = Meteor.settings.public.stripe_live_publishable
#         Template.instance().checkout = StripeCheckout.configure(
#             key: pub_key
#             image: 'http://res.cloudinary.com/facet/image/upload/c_fill,g_face,h_300,w_300/k2zt563boyiahhjb0run'
#             locale: 'auto'
#             # zipCode: true
#             token: (token) =>
#                 # console.log token
#                 # console.log @
#                 # console.log Template.currentData()
#                 # console.log Template.parentData()
#                 # console.log Template.parentData(1)
#                 # console.log Template.parentData(2)
#                 # console.log Template.parentData(3)
#                 # product = Docs.findOne Router.current().params.doc_id
#                 # # console.log product
#                 # console.log @price
#                 charge =
#                     amount: @data.price*100
#                     currency: 'usd'
#                     source: token.id
#                     description: token.description
#                     # receipt_email: token.email
#                 Meteor.call 'STRIPE_single_charge', charge, (error, response) =>
#                     if error then alert error.reason, 'danger'
#                     else
#                         alert 'payment received', 'success'
#                         Meteor.users.update Meteor.userId(),
#                             $inc: karma: @data.amount
#     	)
#
#
#
#     Template.add_karma_amount.events
#         'click .add_karma_amount': ->
#             console.log @
#             Template.instance().checkout.open
#                 name: "#{@amount} karma"
#                 # email:Meteor.user().emails[0].address
#                 description: 'gro shop'
#                 amount: @price*100
