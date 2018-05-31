AuthenticationController = require('../Authentication/AuthenticationController')
SubscriptionController = require('./SubscriptionController')
SubscriptionGroupController = require './SubscriptionGroupController'
TeamInvitesController = require './TeamInvitesController'
Settings = require "settings-sharelatex"

module.exports =
	apply: (webRouter, privateApiRouter, publicApiRouter) ->
		return unless Settings.enableSubscriptions

		webRouter.get  '/user/subscription/plans',      SubscriptionController.plansPage

		webRouter.get  '/user/subscription',            AuthenticationController.requireLogin(), SubscriptionController.userSubscriptionPage

		webRouter.get  '/user/subscription/custom_account', AuthenticationController.requireLogin(), SubscriptionController.userCustomSubscriptionPage

		webRouter.get  '/user/subscription/new',        AuthenticationController.requireLogin(), SubscriptionController.paymentPage

		webRouter.get  '/user/subscription/thank-you', AuthenticationController.requireLogin(), SubscriptionController.successful_subscription


		webRouter.get '/subscription/group',  AuthenticationController.requireLogin(), SubscriptionGroupController.renderSubscriptionGroupAdminPage
		webRouter.post '/subscription/group/user', AuthenticationController.requireLogin(),  SubscriptionGroupController.addUserToGroup
		webRouter.get '/subscription/group/export',  AuthenticationController.requireLogin(), SubscriptionGroupController.exportGroupCsv
		webRouter.delete '/subscription/group/user/:user_id', AuthenticationController.requireLogin(), SubscriptionGroupController.removeUserFromGroup
		webRouter.delete '/subscription/group/email/:email', AuthenticationController.requireLogin(), SubscriptionGroupController.removeEmailInviteFromGroup
		webRouter.delete '/subscription/group/user', AuthenticationController.requireLogin(), SubscriptionGroupController.removeSelfFromGroup

		# Team invites
		webRouter.post '/subscription/invites',  AuthenticationController.requireLogin(),
			TeamInvitesController.createInvite
		webRouter.get '/subscription/invites/:token/',  AuthenticationController.requireLogin(),
			TeamInvitesController.viewInvite
		webRouter.put '/subscription/invites/:token/',  AuthenticationController.requireLogin(),
			TeamInvitesController.acceptInvite
		webRouter.delete '/subscription/invites/:email/',  AuthenticationController.requireLogin(),
			TeamInvitesController.revokeInvite

		webRouter.get '/user/subscription/:subscription_id/group/invited', AuthenticationController.requireLogin(), SubscriptionGroupController.renderGroupInvitePage
		webRouter.post '/user/subscription/:subscription_id/group/begin-join', AuthenticationController.requireLogin(), SubscriptionGroupController.beginJoinGroup
		webRouter.get '/user/subscription/:subscription_id/group/complete-join', AuthenticationController.requireLogin(), SubscriptionGroupController.completeJoin
		webRouter.get '/user/subscription/:subscription_id/group/successful-join', AuthenticationController.requireLogin(), SubscriptionGroupController.renderSuccessfulJoinPage

		#recurly callback
		publicApiRouter.post '/user/subscription/callback',   SubscriptionController.recurlyNotificationParser, SubscriptionController.recurlyCallback

		#user changes their account state
		webRouter.post '/user/subscription/create',     AuthenticationController.requireLogin(), SubscriptionController.createSubscription
		webRouter.post '/user/subscription/update',     AuthenticationController.requireLogin(), SubscriptionController.updateSubscription
		webRouter.post '/user/subscription/cancel',     AuthenticationController.requireLogin(), SubscriptionController.cancelSubscription
		webRouter.post '/user/subscription/reactivate', AuthenticationController.requireLogin(), SubscriptionController.reactivateSubscription

		webRouter.put '/user/subscription/extend', AuthenticationController.requireLogin(), SubscriptionController.extendTrial

		webRouter.get "/user/subscription/upgrade-annual",  AuthenticationController.requireLogin(), SubscriptionController.renderUpgradeToAnnualPlanPage
		webRouter.post "/user/subscription/upgrade-annual",  AuthenticationController.requireLogin(), SubscriptionController.processUpgradeToAnnualPlan

		# Currently used in acceptance tests only, as a way to trigger the syncing logic
		publicApiRouter.post "/user/:user_id/features/sync", AuthenticationController.httpAuth, SubscriptionController.refreshUserFeatures
