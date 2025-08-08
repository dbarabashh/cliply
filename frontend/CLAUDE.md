# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Cliply is a React TypeScript application built with Vite. The project uses pnpm as its package manager.

## Code Architecture Guidelines

### State Management Principles

#### 1. Custom Hooks for Business Logic
- **ALL business logic must be encapsulated in custom hooks**
- Keep components pure and focused only on rendering
- Hooks should be small, focused, and composable
- Place hooks in `src/hooks/` directory

```typescript
// ✅ Good - Logic in hook
const useUserAuth = () => {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);
  
  useEffect(() => {
    // Authentication logic here
  }, []);
  
  return { user, loading, login, logout };
};

// Component only handles rendering
const UserProfile = () => {
  const { user, loading } = useUserAuth();
  
  if (loading) return <Spinner />;
  return <div>{user?.name}</div>;
};
```

#### 2. Global State with Context API
- Use React Context for global application state
- Create separate contexts for different domains (auth, theme, app settings)
- Always provide custom hooks to consume contexts
- Place contexts in `src/contexts/` directory

```typescript
// src/contexts/AuthContext.tsx
const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const AuthProvider: FC<{ children: ReactNode }> = ({ children }) => {
  // Global auth state logic
};

// Custom hook for consuming context
export const useAuth = () => {
  const context = useContext(AuthContext);
  if (!context) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return context;
};
```

#### 3. Complex State with useReducer
- Use `useReducer` for complex state logic in smaller hooks
- Keep reducers pure and predictable
- Define action types explicitly

```typescript
// ✅ Good - Complex state with useReducer
type State = {
  items: Item[];
  filter: string;
  sortBy: 'date' | 'name';
};

type Action = 
  | { type: 'ADD_ITEM'; payload: Item }
  | { type: 'SET_FILTER'; payload: string }
  | { type: 'SET_SORT'; payload: 'date' | 'name' };

const useItemManager = () => {
  const [state, dispatch] = useReducer(reducer, initialState);
  
  const addItem = useCallback((item: Item) => {
    dispatch({ type: 'ADD_ITEM', payload: item });
  }, []);
  
  return { ...state, addItem, setFilter, setSort };
};
```

#### 4. Simple State with useState
- Use `useState` ONLY for simple, local component state
- Examples: toggle states, form inputs, UI-only state

```typescript
// ✅ Good - Simple UI state
const Modal = () => {
  const [isOpen, setIsOpen] = useState(false);
  return <div>...</div>;
};

// ❌ Bad - Complex logic in component
const Modal = () => {
  const [user, setUser] = useState();
  const [permissions, setPermissions] = useState();
  // Complex business logic here - should be in a hook!
};
```

### Component Architecture

#### Reusable Components Rules
1. **No application-specific logic** - Components in `src/components/` should be generic
2. **Props-driven** - All data and callbacks come through props
3. **Self-contained styles** - Use CSS modules or styled components
4. **Fully typed** - Define explicit TypeScript interfaces for props

```typescript
// src/components/Button/Button.tsx
interface ButtonProps {
  variant?: 'primary' | 'secondary';
  size?: 'small' | 'medium' | 'large';
  onClick?: () => void;
  disabled?: boolean;
  children: ReactNode;
}

// ✅ Pure, reusable component
export const Button: FC<ButtonProps> = ({ 
  variant = 'primary',
  size = 'medium',
  onClick,
  disabled,
  children 
}) => {
  return (
    <button 
      className={`btn btn-${variant} btn-${size}`}
      onClick={onClick}
      disabled={disabled}
    >
      {children}
    </button>
  );
};
```

### Directory Structure

```
src/
├── components/         # Reusable UI components (no app logic)
│   ├── Button/
│   ├── Modal/
│   └── Form/
├── hooks/             # Custom hooks with business logic
│   ├── useAuth.ts
│   ├── useApi.ts
│   └── useLocalStorage.ts
├── contexts/          # Global state contexts
│   ├── AuthContext.tsx
│   └── ThemeContext.tsx
├── pages/             # Page components (compose hooks & components)
│   ├── Home/
│   └── Dashboard/
├── utils/             # Pure utility functions
└── types/             # TypeScript type definitions
```

### Best Practices Checklist

#### When Creating Components:
- [ ] Is all business logic in hooks?
- [ ] Are reusable components free of app-specific logic?
- [ ] Is complex state managed with useReducer?
- [ ] Is global state in Context?
- [ ] Are all props and state properly typed?
- [ ] Are hooks small and focused on a single concern?

#### Hook Patterns:
- [ ] Hooks start with `use` prefix
- [ ] Hooks return consistent interface (object with state and methods)
- [ ] Side effects are properly managed with useEffect
- [ ] Dependencies arrays are complete and correct
- [ ] Cleanup functions are provided where needed

#### State Management:
- [ ] useState for simple, local UI state only
- [ ] useReducer for complex state logic
- [ ] Context for truly global state
- [ ] No prop drilling beyond 2 levels

## Common Development Commands

### Frontend (from `frontend/` directory)

```bash
# Install dependencies
pnpm install

# Start development server with HMR
pnpm dev

# Run linting
pnpm lint

# Build for production (runs TypeScript check then Vite build)
pnpm build

# Preview production build locally
pnpm preview
```

## TypeScript Configuration
- Strict mode enabled with additional safety checks
- Always define explicit types for function parameters and return values
- Use interfaces for object shapes, types for unions/intersections
- Avoid `any` type - use `unknown` if type is truly unknown

## Performance Considerations
- Memoize expensive computations with `useMemo`
- Memoize callbacks passed to children with `useCallback`
- Use React.memo for expensive pure components
- Lazy load routes and heavy components with React.lazy()