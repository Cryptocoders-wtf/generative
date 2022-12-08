
# Put original svg files into dir.

```
data/${dirname}/{$filename}.svg
```

# Run

npm run convert ./data/${dirname} ${ContractNamePrefix}

```
npm run convert ./data/londrina_solid_C/ FontC
```

# Generate files

### converted svg

```
outputs/${dirname}/svgs/{$filename}.svg
```

### data

```
outputs/${dirname}/data/data.txt
```

### SVG Data's Smart Contract

```
outputs/${dirname}/data/${ContractNamePrefix}{$filename}.sol
```


# Copy SVG Data's Smart Contract

Copy those files into contracts/contracts/imageParts/

```
mkdir ../contracts/imageParts/${dirname}
mv outputs/${dirname}/data/ ../contracts/imageParts/${dirname}
```


# Create provider and token.

Create provider and token by following to files below.

- contract/contracts/imageParts/logos/LogoArt1.sol
- contract/contracts/providers/LogoArtProvider.sol
- contract/contracts/LogoToken.sol 