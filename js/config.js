var api = {
  baseUrl: 'https://52.52.3.44/portal/api-auth'
}

axios.defaults.baseURL = api.baseUrl;
axios.defaults.timeout = 5000;