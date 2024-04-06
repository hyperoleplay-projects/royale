Vue.config.productionTip = false
Vue.config.devtools = false

const remote = new Proxy({}, {
  get(cache, key) {
    if (!cache[key]) {
      cache[key] = (...args) => app.callback('remote', key, ...args).then(([ok, res]) => (
        ok ? res : Promise.reject(res)
      ))
    }
    return cache[key]
  }
})

const popups = []

const sleep = ms => new Promise(res => setTimeout(res, ms))

const app = new Vue({
  el: '#root',
  data: {
    visible: !!location.port,
    pending: 0,

    credits: [],
    checkout: false,
    form: {},

    popup: {},

    iframe_url: '',
    iframe_padding: '8rem',

    error: '',
    lang: {},
  },
  computed: {
    filtered() {
      return this.credits.slice(0, 3)
    },
    iframe_border_radius() {
      return this.iframe_padding == '0' ? '0' : '1rem'
    }
  },
  watch: {
    categories(v) {
      this.category = v[0]
    },
    checkout() {
      this.form = {}
      this.error = ''
    }
  },
  methods: {
    callback(name, ...args) {
      const script = window.GetParentResourceName?.()
      return fetch(`http://${script}/${name}`, {
        method: 'POST',
        body: JSON.stringify(args)
      }).then(res => res.json())
    },
    remote(name, ...args) {
      return this.callback('remote', name, ...args)
    },
    open_iframe(url) {
      this.iframe_url = url
      this.iframe_padding = '8rem'
    },
    toggle_iframe() {
      const fullscreen = this.iframe_padding == '0'
      if (fullscreen) {
        this.iframe_padding = '8rem'
      } else {
        this.iframe_padding = '0'
      }
    },
    open_url(url) {
      window.invokeNative('openUrl', url)
    },
    add_popup(name, image) {
      const img = new Image()
      img.onload = img.onerror = async () => {
        popups.push({ name, image, visible: true })
        if (!popups.running) {
          popups.running = true

          let next
          while (next = popups.shift()) {
            this.popup = next
            await sleep(3000)
            this.popup = {}
            await sleep(500)
          }

          this.popup = {}
          popups.running = false
        }
      }
      img.src = image
    },
    set_visible(b) {
      this.visible = b
    },
    set_credits(credits) {
      this.credits = credits
    },
    set_pending(count) {
      this.pending = count
    },
    redeem() {
      const item = this.checkout

      remote.redeem(item.id, this.form).then(() => {
        this.close()
        this.add_popup(item.name, item.image)
      }).catch(err => {
        this.error = err.substring(err.lastIndexOf(':')+1).trim()
      })
    },
    testdrive() {
      if (this.form.vehicle) {
        remote.testdrive(this.form.vehicle)
        this.close()
      } else {
        this.error = this._('select.option')
      }
    },
    close() {
      this.visible = false
      this.checkout = false
      this.iframe_url = ''
      this.callback('close')
    },
    _(name, args) {
      return this.lang[name]?.replace?.(/:\w+/g, (name) => {
        return args[name.substring(1)]
      })
    },
  },
  created() {
    document.body.style.display = 'block'

    window.onmessage = ({ data }) => {
      if (Array.isArray(data)) {
        const method = data.shift()
        this[method]?.(...data)
      }
    }

    window.onkeydown = ({ key }) => {
      if (key === 'Escape') {
        this.close()
      }
    }

    this.callback('get_lang').then(lang => this.lang = lang)
  }
})

if (location.hostname === '127.0.0.1') {
  app.credits = [
    {
      name: 'Casa Luxury',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 1,
      category: 'Casas',
      label: 'Escolha uma casa',
      form: [
        {
          label: 'Escolha uma casa',
          options: [
            { label: 'LX50', value: 'LX50' }
          ]
        }
      ],
      consume: 1
    },
    {
      name: 'Número de Telefone',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 1,
      label: 'Insira seu novo número',
      placeholder: '000-000',
      consume: 1
    },
    {
      name: 'Casa Luxury',
      category: 'Casas',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 0,
      consume: 1
    },
    {
      name: 'Casa Luxury',
      category: 'Casas',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 0,
      consume: 1
    },
    {
      name: 'Casa Luxury',
      category: 'Casas',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 0,
      consume: 1
    },
    {
      name: 'Casa Luxury',
      category: 'Casas',
      image: 'https://external-content.duckduckgo.com/iu/?u=http%3A%2F%2Fwww.thestar.com%2Fcontent%2Fdam%2Fthestar%2Flife%2Fhomes%2F2011%2F05%2F19%2Fgta_luxury_housing_includes_8m_oakville_home%2Fluxury1.jpeg&f=1&nofb=1',
      credits: 0,
      consume: 1
    }
  ]
  app.lang = {
    'redeem.one': 'Resgatar um',
    'redeem.many': 'Resgatar vários',
    'redeem': 'Resgatar',
    'confirm': 'Confirmar',
    'credits.insufficient': 'Créditos insuficientes',
    'testdrive': 'TEST DRIVE'
  }
}