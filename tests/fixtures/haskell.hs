import Data.List

permutations :: [a] -> [[a]]
permutations [] = [[]]
permutations xs = do
    x <- xs
    xsRest <- permutations $ filter (/=x) xs
    return $ map (x:) xsRest

