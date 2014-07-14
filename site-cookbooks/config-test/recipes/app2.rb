
node.default[:config].merge!({
	app2_password: 'P@ssw0rd'
})

include_recipe 'config-test::conf'
