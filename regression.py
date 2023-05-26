import sys
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures
import matplotlib.pyplot as plt
import numpy as np

# Read the CSV file into a pandas DataFrame
data = pd.read_csv(sys.argv[1])

# Extract the input and output columns
X = data['pressao'].values.reshape(-1, 1)

for output in ['temperatura', 'entalpia', 'densidade']:
    y = data[output].values

    # Perform polynomial feature transformation
    degree = 3  # Set the degree of the polynomial
    poly_features = PolynomialFeatures(degree=degree)
    X_poly = poly_features.fit_transform(X)

    # Create and fit the polynomial regression model
    model = LinearRegression()
    model.fit(X_poly, y)

    # Print the coefficients and intercept of the polynomial regression model
    print(f"=========pressao -> {output} ========")
    print(f"Intercept ({output}):", model.intercept_)
    print(f"Coefficients ({output}):", model.coef_)

    # Generate additional points for smoother visualization
    X_range = np.linspace(X.min() - 100000, X.max() + 100000, num=300).reshape(-1, 1)
    X_poly_range = poly_features.transform(X_range)

    # Predict using the trained model
    y_pred = model.predict(X_poly_range)

    # Generate a plot of the predictions
    plt.scatter(X, y, color='blue', label='Actual')
    plt.plot(X_range, y_pred, color='red', label='Predicted')
    plt.xlabel('pressao')
    plt.ylabel(output)
    plt.title(f"Polynomial Regression: pressao -> {output}")
    plt.legend()
    plt.show()
