import sys
import pandas as pd
from sklearn.linear_model import LinearRegression
from sklearn.preprocessing import PolynomialFeatures

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

    # Print the coefficients in a useful form
    coefficients = model.coef_
    bias = model.intercept_
    equation = f"{output}(x) = {bias:.6f}"
    for i in range(1, len(coefficients)):
        equation += f" + {coefficients[i]:.6f}x^{i}"
    print(equation)
