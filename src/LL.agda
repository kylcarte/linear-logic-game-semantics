
module LL where

open import Prelude hiding (_&_ ; ¬_ ; _∎) renaming (⊥ to Void ; ⊤ to Unit)

infixr 8 _&_ _⊗_
infixr 7 _⅋_ _⊕_
data U : Set where
  𝟘 𝟙 : U
  ⊤ ⊥ : U
  ¬_  : U → U
  _&_ _⅋_ : (A B : U) → U
  _⊗_ _⊕_ : (A B : U) → U

_⁻¹ : U → U
𝟘 ⁻¹ = ⊤
𝟙 ⁻¹ = ⊥
⊤ ⁻¹ = 𝟘
⊥ ⁻¹ = 𝟙
(¬ A) ⁻¹ = A
(A & B) ⁻¹ = A ⁻¹ ⊕ B ⁻¹
(A ⅋ B) ⁻¹ = A ⁻¹ ⊗ B ⁻¹
(A ⊗ B) ⁻¹ = A ⁻¹ ⅋ B ⁻¹
(A ⊕ B) ⁻¹ = A ⁻¹ & B ⁻¹

replace : ∀ {a} {A : Set a} → Nat → A × List A → A × List A
replace i       (x , []     ) = x , []
replace zero    (x , x₁ ∷ xs) = x₁ , x ∷ xs
replace (suc i) (x , x₁ ∷ xs) = second (_∷_ x₁) (replace i (x , xs))

-- replace-inv : ∀ {a} {A : Set a} (i : Nat) {x : A} {xs : List A} → replace i (replace i (x , xs)) ≡ (x , xs)

swap : ∀ {a} {A : Set a} → Nat × Nat → List A → List A
swap (i , j) []               = []
swap (zero , zero)   xs       = xs
swap (zero , suc j)  (x ∷ xs) = uncurry _∷_ (replace j (x , xs))
swap (suc i , zero)  (x ∷ xs) = uncurry _∷_ (replace i (x , xs))
swap (suc i , suc j) (x ∷ xs) = x ∷ swap (i , j) xs

Permutation : Set
Permutation = List (Nat × Nat)

permute : ∀ {a} {A : Set a} → Permutation → List A → List A
permute = foldr (λ ij k → swap ij ∘ k) id

infix 4 _≡_⊎_

data _≡_⊎_ {a} {A : Set a} : List A → List A → List A → Set a where
  ∎  : [] ≡ [] ⊎ []
  ◂_ : ∀ {x xs ls rs}
     →     xs ≡     ls ⊎ rs
     → x ∷ xs ≡ x ∷ ls ⊎ rs
  ▸_ : ∀ {x xs ls rs}
     →     xs ≡ ls ⊎     rs
     → x ∷ xs ≡ ls ⊎ x ∷ rs

infix 4 _⊢_
data _⊢_ : List U → List U → Set where
  init : ∀ {A}
       → [ A ] ⊢ [ A ]
  ¬L : ∀ {A Δ Γ Γ'}
     → Γ' ≡ [ A ] ⊎ Γ
     → Δ ⊢ Γ'
     → ¬ A ∷ Δ ⊢ Γ
  ¬R : ∀ {A Δ Δ' Γ}
     → Δ' ≡ [ A ] ⊎ Δ
     → Δ' ⊢ Γ
     → Δ ⊢ ¬ A ∷ Γ
  𝟙L : ∀ {Δ Γ}
     → Δ ⊢ Γ
     → 𝟙 ∷ Δ ⊢ Γ
  𝟙R : [] ⊢ [ 𝟙 ]
  ⊗L : ∀ {A B Δ Δ' Γ}
     → Δ ≡ (A ∷ B ∷ []) ⊎ Δ
     → Δ' ⊢ Γ
     → A ⊗ B ∷ Δ ⊢ Γ
  ⊗R : ∀ {A B Δ Δ₁ Δ₂ Γ Γ₁ Γ₂ Γ₁' Γ₂'}
     → Δ ≡ Δ₁ ⊎ Δ₂
     → Γ ≡ Γ₁ ⊎ Γ₂
     → Γ₁' ≡ [ A ] ⊎ Γ₁
     → Γ₂' ≡ [ B ] ⊎ Γ₂
     → Δ₁ ⊢ Γ₁'
     → Δ₂ ⊢ Γ₂'
     → Δ ⊢ A ⊗ B ∷ Γ
  ⅋L : ∀ {A B Δ Δ₁ Δ₂ Δ₁' Δ₂' Γ Γ₁ Γ₂}
     → Δ ≡ Δ₁ ⊎ Δ₂
     → Γ ≡ Γ₁ ⊎ Γ₂
     → Δ₁' ≡ [ A ] ⊎ Δ₁
     → Δ₂' ≡ [ B ] ⊎ Δ₂
     → Δ₁' ⊢ Γ₁
     → Δ₂' ⊢ Γ₂
     → A ⅋ B ∷ Δ ⊢ Γ
  ⅋R : ∀ {A B Δ Γ Γ'}
     → Γ' ≡ (A ∷ B ∷ []) ⊎ Γ
     → Δ ⊢ Γ'
     → Δ ⊢ A ⅋ B ∷ Γ
  ⊥L : [ ⊥ ] ⊢ []
  ⊥R : ∀ {Δ Γ}
     → Δ ⊢ Γ
     → Δ ⊢ ⊥ ∷ Γ
  𝟘L : ∀ {Δ Γ}
     → 𝟘 ∷ Δ ⊢ Γ
  ⊤R : ∀ {Δ Γ}
     → Δ ⊢ ⊤ ∷ Γ
  &L₁ : ∀ {A B Δ Δ' Γ}
      → Δ' ≡ [ A ] ⊎ Δ
      → Δ' ⊢ Γ
      → A & B ∷ Δ ⊢ Γ
  &L₂ : ∀ {A B Δ Δ' Γ}
      → Δ' ≡ [ B ] ⊎ Δ
      → Δ' ⊢ Γ
      → A & B ∷ Δ ⊢ Γ
  &R : ∀ {A B Δ Γ}
     → Δ ⊢ A ∷ Γ
     → Δ ⊢ B ∷ Γ
     → Δ ⊢ A & B ∷ Γ
  ⊕L : ∀ {A B Δ Δ' Δ'' Γ}
     → Δ'  ≡ [ A ] ⊎ Δ
     → Δ'' ≡ [ B ] ⊎ Δ
     → A ∷ Δ ⊢ Γ
     → B ∷ Δ ⊢ Γ
     → A ⊕ B ∷ Δ ⊢ Γ
  ⊕R₁ : ∀ {A B Δ Γ Γ'}
      → Γ' ≡ [ A ] ⊎ Γ
      → Δ ⊢ Γ'
      → Δ ⊢ A & B ∷ Γ
  ⊕R₂ : ∀ {A B Δ Γ Γ'}
      → Γ' ≡ [ B ] ⊎ Γ
      → Δ ⊢ Γ'
      → Δ ⊢ A & B ∷ Γ

infix 4 _⊸_
pattern _⊸_ A B = ¬ A ⅋ B

p₁ : ∀ {A B} → [] ⊢ [ ((A ⊸ B) ⊸ 𝟘) ⊸ (A ⊗ ⊤) ]
p₁ =
  ⅋R (◂ ◂ ∎)
  $ ¬R (◂ ∎)
  $ ⅋L ∎ (◂ ∎) (◂ ∎) (◂ ∎)
    (¬L (◂ ▸ ∎)
    $ ⅋R (◂ ▸ ◂ ∎)
    $ ¬R (◂ ∎)
    $ ⊗R (◂ ∎) (▸ ∎) (◂ ∎) (◂ ▸ ∎)
      init
      ⊤R
    )
    𝟘L
