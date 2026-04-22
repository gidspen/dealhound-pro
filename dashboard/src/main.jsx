import { render } from 'preact';

function App() {
  return <div style={{ padding: '40px', fontFamily: 'Outfit, sans-serif' }}>Preact works</div>;
}

render(<App />, document.getElementById('app'));
