if Meteor.isClient

	comp.page = (add) ->
		view: -> m 'main', [comp.menu, comp[add]]

	comp.login =
		controller: reactive ->
			this.formEvent = ->
				onsubmit: (event) ->
					event.preventDefault()
					obj = {}; _.map ['username', 'password'], (i) ->
						obj[i] = event.target.children[i].value
					Meteor.loginWithPassword obj.username, obj.password
		view: (ctrl) -> m '.container'
			, m 'form', ctrl.formEvent(), [
				m 'input', name: 'username', placeholder: 'Username'
				m 'input', name: 'password', placeholder: 'Password', type: 'password'
				m 'input.btn', type: 'submit', value: 'Login'
			]

	comp.menu =
		init: ->
			$('.collapsible').collapsible()
		view: ->
			m '.navbar-fixed', m 'nav.green', m '.nav-wrapper', [
				m 'ul.left.hide-on-med-and-down', style: 'padding-left': '240px'
				, _.map ['Beranda', 'Panduan'], (i) -> m 'li', m 'a', i
				m 'a.brand-logo.center', 'DISLHK'
				m 'ul.right.hide-on-med-and-down'
				, _.map ['login', 'register'], (i) -> m 'li', m 'a', href: '/'+i, _.startCase i
				Meteor.userId() and m 'ul.fixed.side-nav', [
					m 'li.grey.lighten-2', m 'a', m 'b', 'Admin Menu'
					_.map kabs, (i) -> m 'li', m 'ul.collapsible', m 'li', [
						m '.collapsible-header', m '.black-text', _.startCase i
						_.map kawasan, (j) -> m 'a.collapsible-body',
							href: '/peta/'+i+'/'+j
						, _.upperCase j
					]
				]
			]

	comp.peta =
		config: ->
			map = L.map 'peta',
				center: [0.5, 101]
				zoom: 8
				zoomControl: false
			sel =
				kab: m.route.param 'kab'
				kaw: m.route.param 'kaw'
			geojson = L.geoJson.ajax '/maps/'+sel.kab+'_'+sel.kaw+'.geojson',
				style: (feature) ->
					fillColor: '#'+Math.random().toString(16).substr(-6)
					weight: 2
					opacity: 1
					color: 'white'
					dashArray: '3'
					fillOpacity: 0.7
				onEachFeature: (feature, layer) ->
					layer.on
						mouseover: (event) ->
							event.target.setStyle
								weight: 5
								color: '#666'
								dashArray: ''
								fillOpacity: 0.7
							event.target.bringToFront()
						mouseout: (event) ->
							geojson.resetStyle event.target
						click: (event) ->
							map.fitBounds event.target.getBounds()
					layer.bindPopup ->
						content = ''
						for key, val of feature.properties
							content += '<b>Data '+key+'</b>'+': '+val+'<br/>'
						content
			geojson.addTo map
			topo = L.tileLayer.provider 'OpenTopoMap'
			topo.addTo map
		view: ->
			m '#peta',
				config: this.config
				style: height: '600px'

	comp.beranda =
		list: [
			title: 'Panduan Aplikasi'
			desc: 'Baca disini'
			img: 'http://lorempixel.com/580/250/nature/1'
		,
			title: 'Keterangan Peta'
			desc: 'Baca disini juga'
			img: ''
		]
		config: ->
			$('.slider').slider()
		view: ->
			m '.slider', config: this.config, m 'ul.slides', _.map this.list, (i) ->
				m 'li', [
					m 'img', src: i.img
					m '.caption.center-align', [
						m 'h3', i.title
						m 'h5', i.desc
					]
				]

	m.route.mode = 'pathname'
	m.route document.body, '/peta/bengkalis/apl',
		'/peta/:kab/:kaw': comp.page 'peta'
		'/beranda': comp.page 'beranda'
		'/login': comp.page 'login'
