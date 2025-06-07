//backend\src\utils\error.js
export const handleError = (res, error) => {
    const statusCode = error.statusCode || 500;
    const message = error.message || 'Internal Server Error';
    
    res.status(statusCode).json({
        status: 'error',
        statusCode,
        message,
    });
};

export const notFound = (res) => {
    res.status(404).json({
        status: 'error',
        statusCode: 404,
        message: 'Resource not found',
    });
};