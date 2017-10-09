if Meteor.isClient

	comp.layout =
		view: -> m 'main', [comp.menu, comp.peta]

	comp.menu =
		init: ->
			$('.collapsible').collapsible()
		view: ->
			m '.navbar-fixed', m 'nav.green', m '.nav-wrapper', [
				m 'ul.left', style: 'padding-left': '300px'
				, _.map ['Beranda', 'Panduan'], (i) -> m 'li', m 'a', i
				m 'a.brand-logo.center', 'DISLHK'
				m 'ul.right', _.map ['Masuk', 'Daftar'], (i) -> m 'li', m 'a', i
				m 'ul.fixed.side-nav', [
					m 'li', m 'a', m 'b', 'Admin Menu'
					_.map kabs, (i) -> m 'li', m 'ul.collapsible', m 'li', [
						m '.collapsible-header', m '.black-text', _.startCase i
						_.map kawasan, (j) -> m 'a.collapsible-body', _.upperCase j
					]
				]
			]

	comp.peta =
		config: ->
			sel =
				kab: m.route.param 'kab'
				kaw: m.route.param 'kaw'
			map = L.map 'peta',
				center: [0.5, 101]
				zoom: 8
				zoomControl: false
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

	m.route.mode = 'pathname'
	m.route document.body, '/peta/bengkalis/apl',
		'/peta/:kab/:kaw': comp.layout
