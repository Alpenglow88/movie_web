const filmsData = require('../../../films.json')

const createFilmTemplate = data => (`
    <div class="section">
            <div class="section-title">${data.film}</div>
            <img class="section-image" src="${data.imageUrl}"></div>
        </div>
`)

const components = filmsData
    .map(currentData => createFilmTemplate(currentData))
    .reduce((output, current) => {
        output = output + current
        return output
    }, '')

const RootComponent = `
    <div class="root">
        ${components}
    </div>
`

translate to Ruby