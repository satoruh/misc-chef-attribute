
node.default[:config].merge!({
	app1_password: 'password4app1'
})

include_recipe 'config-test::conf'
