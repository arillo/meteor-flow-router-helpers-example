@Posts = new Mongo.Collection 'posts'
@Comments = new Mongo.Collection 'comments'

FlowRouter.route '/',
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'Index'})
  name: 'root'

FlowRouter.route '/posts',
  subscriptions: (params, queryParams) ->
    @register('posts', Meteor.subscribe('posts'))
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'Posts'})
  name: 'posts'

FlowRouter.route '/post/:id',
  subscriptions: (params, queryParams) ->
    @register('comments', Meteor.subscribe('comments', params.id))
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'Post'})
  name: 'post'

FlowRouter.route '/post/:id/comment/:cid',
  subscriptions: (params, queryParams) ->
    @register('comments', Meteor.subscribe('comment', params.cid))
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'PostComment'})
  name: 'postComment'

FlowRouter.route '/dashboard/invites',
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'DashboardInvites'})
  name: 'dashboardInvites'

FlowRouter.route '/queryparams',
  action: (params) ->
    BlazeLayout.render('HomeLayout', { main:'QueryParams'})
  name: 'queryParams'

adminRoutes = FlowRouter.group
  prefix: '/admin'
  name: 'admin'
  # triggersEnter: [(context, redirect) ->
  #   console.log('running group triggers')
  # ]

adminRoutes.route '/posts',
  name: 'adminPosts'
  action: () ->
    BlazeLayout.render('HomeLayout', {main: 'AdminGroupPosts'})


if Meteor.isServer
  Meteor.startup () ->
    if Posts.find().count() < 1
      _.each [1..4], (num) ->
        post_id = Posts.insert
          title: "Post nr.: #{num}"
          description: "lorem ipsum dolor sit amet"
        _.each [1..num], (num) ->
          Comments.insert
            title: "Comment nr.: #{num}"
            description: "lorem ipsum dolor sit amet"
            post_id: post_id

  Meteor.publish 'posts', () ->
    Posts.find()

  Meteor.publish 'post', (_id) ->
    Posts.find(_id:_id)

  Meteor.publish 'comments', (post_id) ->
    Comments.find(post_id:post_id)

  Meteor.publish 'comment', (_id) ->
    Comments.find(_id:_id)

if Meteor.isClient

  Template.Post.onCreated () ->
    self = @
    self.autorun () ->
      self.subscribe 'post', FlowRouter.getParam('id')
      if self.subscriptionsReady()
        console.log 'subscriptionsReady'

  Template.PostComment.helpers
    comment: () ->
      Comments.findOne(_id: FlowRouter.getParam('cid'))

  Template.Post.helpers
    comments: () ->
      Comments.find()
    post: () ->
      Posts.findOne(_id: FlowRouter.getParam('id'))

  Template.Posts.helpers
    posts: () ->
      Posts.find()
  
  Template.QueryParams.helpers
    getQueryParams: () ->
      current = FlowRouter.current()
      return FlowRouter._qs.stringify(current.queryParams)