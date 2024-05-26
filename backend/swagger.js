const swaggerJSDoc = require('swagger-jsdoc');
const swaggerUi = require('swagger-ui-express');

const options = {
    definition: {
        openapi: '3.0.0',
        info: {
            title: 'Issue Tracker API',
            version: '1.0.0',
            description: 'API documentation for the Issue Tracker application',
        },
    },
    apis: ['./routes/*.js'], // Lokacija datotek z anotacijami
};

const swaggerSpec = swaggerJSDoc(options);

function setupSwagger(app) {
    app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));
}

module.exports = setupSwagger;
